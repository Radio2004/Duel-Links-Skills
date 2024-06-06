--Darkfluid Link
--Empty, Infinite, and Infinite Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		--spsummon limit
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetTarget(s.splimit)
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone(e2)
		e3:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e3,tp)
	end
	e:SetLabel(1)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE)
end

function s.spcfilter(c)
	return (c:IsSetCard(SET_FIREWALL) or c:IsRitualMonster()) and c:IsMonster() and not c:IsPublic()
end

function s.thfilter(c)
	return c:IsSetCard(SET_CYNET) and c:IsSpell() and c:IsAbleToHand()
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+1)>0 then return end
	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsLink,tp,LOCATION_EXTRA,0,1,nil,5)
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.GetFlagEffect(tp,id+2)~=0


	return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsLink,tp,LOCATION_EXTRA,0,1,nil,5)
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.GetFlagEffect(tp,id+2)~=0

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								   {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if tc then
		local keyMonster={24731391,21065189,5043010,63533837,42717221}
		for i=1,#keyMonster do
			local g=Duel.CreateToken(tp,keyMonster[i])
			  Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			  g:CompleteProcedure()
		end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end