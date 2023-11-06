--Empty, Infinite, and Infinite Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	aux.AddSkillProcedure(c,2,false,s.flipcon2,s.flipop2)
end


function s.sendToGrave(c)
	return c:IsAbleToGraveAsCost()
end

function s.removedFromField(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsCode(9409625,36894320,72883039) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.sephylon(c)
	return c:IsCode(8967776) and not c:IsPublic()
end



function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id+1)>0 and Duel.GetFlagEffect(tp,id+2)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id+1)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b2=Duel.GetFlagEffect(tp,id+2)==0
		and eg:IsExists(s.removedFromField,1,nil,tp) and Duel.IsExistingMatchingCard(s.sephylon,tp,LOCATION_HAND,0,1,nil)

	return aux.CanActivateSkill(tp) and (b1 or b2)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp, id+1)==0
		and Duel.IsExistingMatchingCard(s.sendToGrave,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0

	local b2=Duel.GetFlagEffect(tp,id+2)==0 and Duel.IsExistingMatchingCard(s.sephylon,tp,LOCATION_HAND,0,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								   {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

--op=0 set 1 "Empty Machine" from outside the duel to your Spell/Trap Zone.
function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.sendToGrave,tp,LOCATION_HAND,0,1,1,false,nil)
	if Duel.SendtoGrave(tg,REASON_EFFECT) then
		local cearth=Duel.CreateToken(tp,9409625)
		if Duel.SSet(tp,cearth)>0 then
			--Can be activated the turn it was Set
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			cearth:RegisterEffect(e1)

		end
	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp, s.genexcontroller_send_filter,tp, LOCATION_HAND,0,1,1,false,nil)
	local cearth=Duel.CreateToken(tp, 9409625)
	Duel.SSet(tp,cearth)
	Duel.RegisterFlagEffect(tp,id+2,0,0,0)
end
